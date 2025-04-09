package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/xclean/backend/internal/handlers"
)

func SetupAppointmentRoutes(router *gin.Engine, appointmentHandler *handlers.AppointmentHandler) {
	appointments := router.Group("/api/appointments")
	{
		// Criar novo agendamento
		appointments.POST("/", appointmentHandler.CreateAppointment)

		// Listar agendamentos do usuário
		appointments.GET("/user", appointmentHandler.GetUserAppointments)

		// Listar agendamentos da prestadora
		appointments.GET("/provider", appointmentHandler.GetProviderAppointments)

		// Atualizar status do agendamento
		appointments.PATCH("/:id/status", appointmentHandler.UpdateAppointmentStatus)

		// Buscar prestadoras disponíveis
		appointments.GET("/available-providers", appointmentHandler.GetAvailableProviders)
	}
}
