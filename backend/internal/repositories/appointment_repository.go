package repositories

import (
	"errors"
	"time"

	"github.com/xclean/backend/internal/models"
	"gorm.io/gorm"
)

var (
	ErrAppointmentNotFound = errors.New("agendamento não encontrado")
)

type AppointmentRepository struct {
	db *gorm.DB
}

func NewAppointmentRepository(db *gorm.DB) *AppointmentRepository {
	return &AppointmentRepository{
		db: db,
	}
}

// Create cria um novo agendamento
func (r *AppointmentRepository) Create(appointment *models.Appointment) error {
	return r.db.Create(appointment).Error
}

// FindByID busca um agendamento pelo ID
func (r *AppointmentRepository) FindByID(id uint) (*models.Appointment, error) {
	var appointment models.Appointment
	if err := r.db.First(&appointment, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrAppointmentNotFound
		}
		return nil, err
	}
	return &appointment, nil
}

// GetUserAppointments retorna os agendamentos de um usuário
func (r *AppointmentRepository) GetUserAppointments(userID uint, status string) ([]models.Appointment, error) {
	var appointments []models.Appointment
	query := r.db.Where("user_id = ?", userID)

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if err := query.Order("date DESC").Find(&appointments).Error; err != nil {
		return nil, err
	}

	return appointments, nil
}

// GetProviderAppointments retorna os agendamentos de uma prestadora
func (r *AppointmentRepository) GetProviderAppointments(providerID uint, status string) ([]models.Appointment, error) {
	var appointments []models.Appointment
	query := r.db.Where("provider_id = ?", providerID)

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if err := query.Order("date DESC").Find(&appointments).Error; err != nil {
		return nil, err
	}

	return appointments, nil
}

// UpdateStatus atualiza o status de um agendamento
func (r *AppointmentRepository) UpdateStatus(id uint, status models.AppointmentStatus) error {
	return r.db.Model(&models.Appointment{}).Where("id = ?", id).Update("status", status).Error
}

// GetAvailableProviders retorna as prestadoras disponíveis para um determinado horário
func (r *AppointmentRepository) GetAvailableProviders(date time.Time, service string) ([]models.User, error) {
	var providers []models.User

	// Busca prestadoras que oferecem o serviço solicitado
	// e não têm agendamentos no horário solicitado
	query := `
		SELECT u.* FROM users u
		JOIN provider_profiles p ON u.id = p.user_id
		WHERE u.user_type = 'provider'
		AND u.is_active = true
		AND p.is_verified = true
		AND NOT EXISTS (
			SELECT 1 FROM appointments a
			WHERE a.provider_id = u.id
			AND a.date = ?
			AND a.status != 'cancelled'
		)
	`

	if err := r.db.Raw(query, date).Scan(&providers).Error; err != nil {
		return nil, err
	}

	return providers, nil
}
