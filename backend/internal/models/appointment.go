package models

import (
	"time"
)

// AppointmentStatus define os possíveis status de um agendamento
type AppointmentStatus string

const (
	AppointmentStatusPending    AppointmentStatus = "pending"
	AppointmentStatusConfirmed  AppointmentStatus = "confirmed"
	AppointmentStatusInProgress AppointmentStatus = "in_progress"
	AppointmentStatusCompleted  AppointmentStatus = "completed"
	AppointmentStatusCancelled  AppointmentStatus = "cancelled"
)

// Appointment representa um agendamento no sistema
type Appointment struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relacionamentos
	UserID     uint `json:"user_id" gorm:"not null"`
	ProviderID uint `json:"provider_id" gorm:"not null"`
	User       User `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Provider   User `json:"provider,omitempty" gorm:"foreignKey:ProviderID"`

	// Dados do agendamento
	Service   string            `json:"service" gorm:"not null"`
	Date      time.Time         `json:"date" gorm:"not null"`
	Time      string            `json:"time" gorm:"not null"`
	Status    AppointmentStatus `json:"status" gorm:"not null;default:'pending'"`
	Notes     string            `json:"notes"`
	Price     float64           `json:"price"`
	Duration  int               `json:"duration"` // Duração em minutos
	Location  string            `json:"location"`
	Latitude  float64           `json:"latitude"`
	Longitude float64           `json:"longitude"`
}
