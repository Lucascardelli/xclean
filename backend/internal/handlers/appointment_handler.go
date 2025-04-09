package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/xclean/backend/internal/models"
	"github.com/xclean/backend/internal/repositories"
	"github.com/xclean/backend/internal/services"
)

type AppointmentHandler struct {
	appointmentRepo *repositories.AppointmentRepository
	userRepo        *repositories.UserRepository
	authService     *services.AuthService
}

func NewAppointmentHandler(
	appointmentRepo *repositories.AppointmentRepository,
	userRepo *repositories.UserRepository,
	authService *services.AuthService,
) *AppointmentHandler {
	return &AppointmentHandler{
		appointmentRepo: appointmentRepo,
		userRepo:        userRepo,
		authService:     authService,
	}
}

type CreateAppointmentRequest struct {
	ProviderID uint      `json:"provider_id" binding:"required"`
	Service    string    `json:"service" binding:"required"`
	Date       time.Time `json:"date" binding:"required"`
	Time       string    `json:"time" binding:"required"`
	Notes      string    `json:"notes"`
	Location   string    `json:"location"`
	Latitude   float64   `json:"latitude"`
	Longitude  float64   `json:"longitude"`
}

// CreateAppointment cria um novo agendamento
func (h *AppointmentHandler) CreateAppointment(c *gin.Context) {
	// Obter usuário autenticado
	userID, err := h.getUserIDFromToken(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Não autorizado"})
		return
	}

	var req CreateAppointmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verificar se a prestadora existe
	provider, err := h.userRepo.FindByID(req.ProviderID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Prestadora não encontrada"})
		return
	}

	if provider.UserType != models.UserTypeProvider {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Usuário não é uma prestadora"})
		return
	}

	// Criar agendamento
	appointment := &models.Appointment{
		UserID:     userID,
		ProviderID: req.ProviderID,
		Service:    req.Service,
		Date:       req.Date,
		Time:       req.Time,
		Status:     models.AppointmentStatusPending,
		Notes:      req.Notes,
		Location:   req.Location,
		Latitude:   req.Latitude,
		Longitude:  req.Longitude,
	}

	if err := h.appointmentRepo.Create(appointment); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao criar agendamento"})
		return
	}

	c.JSON(http.StatusCreated, appointment)
}

// GetUserAppointments retorna os agendamentos do usuário autenticado
func (h *AppointmentHandler) GetUserAppointments(c *gin.Context) {
	// Obter usuário autenticado
	userID, err := h.getUserIDFromToken(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Não autorizado"})
		return
	}

	// Obter status do query param (opcional)
	status := c.Query("status")

	// Buscar agendamentos
	appointments, err := h.appointmentRepo.GetUserAppointments(userID, status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao buscar agendamentos"})
		return
	}

	c.JSON(http.StatusOK, appointments)
}

// GetProviderAppointments retorna os agendamentos da prestadora autenticada
func (h *AppointmentHandler) GetProviderAppointments(c *gin.Context) {
	// Obter usuário autenticado
	userID, err := h.getUserIDFromToken(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Não autorizado"})
		return
	}

	// Verificar se o usuário é uma prestadora
	user, err := h.userRepo.FindByID(userID)
	if err != nil || user.UserType != models.UserTypeProvider {
		c.JSON(http.StatusForbidden, gin.H{"error": "Acesso negado"})
		return
	}

	// Obter status do query param (opcional)
	status := c.Query("status")

	// Buscar agendamentos
	appointments, err := h.appointmentRepo.GetProviderAppointments(userID, status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao buscar agendamentos"})
		return
	}

	c.JSON(http.StatusOK, appointments)
}

// UpdateAppointmentStatus atualiza o status de um agendamento
func (h *AppointmentHandler) UpdateAppointmentStatus(c *gin.Context) {
	// Obter usuário autenticado
	userID, err := h.getUserIDFromToken(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Não autorizado"})
		return
	}

	// Obter ID do agendamento
	appointmentID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	// Obter status do body
	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Buscar agendamento
	appointment, err := h.appointmentRepo.FindByID(uint(appointmentID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Agendamento não encontrado"})
		return
	}

	// Verificar permissão
	user, err := h.userRepo.FindByID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao buscar usuário"})
		return
	}

	// Apenas o cliente ou a prestadora podem atualizar o status
	if user.UserType != models.UserTypeAdmin &&
		userID != appointment.UserID &&
		userID != appointment.ProviderID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Acesso negado"})
		return
	}

	// Atualizar status
	if err := h.appointmentRepo.UpdateStatus(uint(appointmentID), models.AppointmentStatus(req.Status)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao atualizar status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Status atualizado com sucesso"})
}

// GetAvailableProviders retorna as prestadoras disponíveis para um determinado horário
func (h *AppointmentHandler) GetAvailableProviders(c *gin.Context) {
	// Obter data do query param
	dateStr := c.Query("date")
	if dateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data não fornecida"})
		return
	}

	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Formato de data inválido"})
		return
	}

	// Obter serviço do query param
	service := c.Query("service")
	if service == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Serviço não fornecido"})
		return
	}

	// Buscar prestadoras disponíveis
	providers, err := h.appointmentRepo.GetAvailableProviders(date, service)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao buscar prestadoras"})
		return
	}

	c.JSON(http.StatusOK, providers)
}

// getUserIDFromToken extrai o ID do usuário do token JWT
func (h *AppointmentHandler) getUserIDFromToken(c *gin.Context) (uint, error) {
	// Extrair token do header
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		return 0, nil
	}

	// Validar formato do token
	if len(authHeader) < 7 || authHeader[:7] != "Bearer " {
		return 0, nil
	}

	tokenString := authHeader[7:]

	// Validar token
	claims, err := h.authService.ValidateToken(tokenString)
	if err != nil {
		return 0, err
	}

	// Extrair ID do usuário
	userID, ok := claims["user_id"].(float64)
	if !ok {
		return 0, nil
	}

	return uint(userID), nil
}
