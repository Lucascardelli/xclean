package models

import (
	"time"
)

// UserType define o tipo de usuário
type UserType string

const (
	UserTypeClient   UserType = "client"
	UserTypeProvider UserType = "provider"
	UserTypeAdmin    UserType = "admin"
)

// User representa um usuário no sistema
type User struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Campos básicos
	Email    string   `json:"email" gorm:"unique;not null"`
	Password string   `json:"-" gorm:"not null"` // O "-" indica que não será serializado para JSON
	Name     string   `json:"name" gorm:"not null"`
	Phone    string   `json:"phone"`
	UserType UserType `json:"user_type" gorm:"not null"`
	IsActive bool     `json:"is_active" gorm:"default:true"`

	// Campos específicos para prestadoras
	ProviderProfile *ProviderProfile `json:"provider_profile,omitempty" gorm:"foreignKey:UserID"`
}

// ProviderProfile representa o perfil de uma prestadora
type ProviderProfile struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	UserID    uint      `json:"user_id" gorm:"unique;not null"`

	// Informações profissionais
	Description   string  `json:"description"`
	HourlyRate    float64 `json:"hourly_rate"`
	ServiceRadius float64 `json:"service_radius"` // Raio de atendimento em km
	IsVerified    bool    `json:"is_verified" gorm:"default:false"`

	// Localização
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Address   string  `json:"address"`

	// Configurações
	AvailableClothes []string `json:"available_clothes" gorm:"type:text[]"` // Lista de roupas permitidas
	WorkingHours     string   `json:"working_hours"`                        // Horário de trabalho em formato JSON
}
