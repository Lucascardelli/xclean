package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/xclean/backend/internal/config"
	"github.com/xclean/backend/internal/handlers"
	"github.com/xclean/backend/internal/repositories"
	"github.com/xclean/backend/internal/routes"
	"github.com/xclean/backend/internal/services"
)

func main() {
	// Inicializa a configuração do banco de dados
	dbConfig := config.NewDatabaseConfig()
	db, err := dbConfig.Connect()
	if err != nil {
		log.Fatal("Erro ao conectar ao banco de dados:", err)
	}

	// Inicializa o router Gin
	r := gin.Default()

	// Configuração de CORS
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Inicializa repositórios
	userRepo := repositories.NewUserRepository(db)
	appointmentRepo := repositories.NewAppointmentRepository(db)

	// Inicializa serviços
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "your-secret-key" // Em produção, sempre use uma chave segura via variável de ambiente
	}
	authService := services.NewAuthService(jwtSecret)
	authHandler := handlers.NewAuthHandler(authService, userRepo)
	appointmentHandler := handlers.NewAppointmentHandler(appointmentRepo, userRepo, authService)

	// Rotas de autenticação
	auth := r.Group("/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.GET("/me", authHandler.Me)
	}

	// Rotas de agendamento
	routes.SetupAppointmentRoutes(r, appointmentHandler)

	// Rota de healthcheck
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
		})
	})

	// Inicia o servidor
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := r.Run(":" + port); err != nil {
		log.Fatal("Erro ao iniciar o servidor: ", err)
	}
}
