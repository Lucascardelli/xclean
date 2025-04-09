package config

import (
	"fmt"
	"log"
	"os"

	"github.com/xclean/backend/internal/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// DatabaseConfig contém as configurações do banco de dados
type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

// NewDatabaseConfig cria uma nova configuração do banco de dados
func NewDatabaseConfig() *DatabaseConfig {
	return &DatabaseConfig{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "xclean"),
		SSLMode:  getEnv("DB_SSL_MODE", "disable"),
	}
}

// Connect estabelece a conexão com o banco de dados
func (c *DatabaseConfig) Connect() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.User, c.Password, c.DBName, c.SSLMode)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, fmt.Errorf("erro ao conectar ao banco de dados: %v", err)
	}

	// Auto-migra os modelos
	err = db.AutoMigrate(
		&models.User{},
		&models.ProviderProfile{},
	)
	if err != nil {
		return nil, fmt.Errorf("erro ao migrar o banco de dados: %v", err)
	}

	log.Println("Banco de dados conectado com sucesso")
	return db, nil
}

// getEnv retorna o valor de uma variável de ambiente ou um valor padrão
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
