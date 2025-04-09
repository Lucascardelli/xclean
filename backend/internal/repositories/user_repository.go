package repositories

import (
	"errors"

	"github.com/xclean/backend/internal/models"
	"gorm.io/gorm"
)

var (
	ErrUserNotFound = errors.New("usuário não encontrado")
	ErrEmailExists  = errors.New("email já cadastrado")
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{
		db: db,
	}
}

// Create cria um novo usuário no banco de dados
func (r *UserRepository) Create(user *models.User) error {
	// Verifica se o email já existe
	var count int64
	r.db.Model(&models.User{}).Where("email = ?", user.Email).Count(&count)
	if count > 0 {
		return ErrEmailExists
	}

	return r.db.Create(user).Error
}

// FindByID busca um usuário pelo ID
func (r *UserRepository) FindByID(id uint) (*models.User, error) {
	var user models.User
	if err := r.db.First(&user, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

// FindByEmail busca um usuário pelo email
func (r *UserRepository) FindByEmail(email string) (*models.User, error) {
	var user models.User
	if err := r.db.Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}
	return &user, nil
}

// Update atualiza os dados de um usuário
func (r *UserRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

// Delete remove um usuário do banco de dados
func (r *UserRepository) Delete(id uint) error {
	return r.db.Delete(&models.User{}, id).Error
}

// CreateProviderProfile cria um perfil de prestadora para um usuário
func (r *UserRepository) CreateProviderProfile(profile *models.ProviderProfile) error {
	return r.db.Create(profile).Error
}

// UpdateProviderProfile atualiza o perfil de uma prestadora
func (r *UserRepository) UpdateProviderProfile(profile *models.ProviderProfile) error {
	return r.db.Save(profile).Error
}

// GetProviderProfile busca o perfil de uma prestadora pelo ID do usuário
func (r *UserRepository) GetProviderProfile(userID uint) (*models.ProviderProfile, error) {
	var profile models.ProviderProfile
	if err := r.db.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}
	return &profile, nil
}
