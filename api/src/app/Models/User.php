<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'User',
    title: 'Utilisateur',
    description: 'Compte utilisateur de l\'application CESIZen',
    properties: [
        new OA\Property(property: 'id_user', type: 'integer', example: 1),
        new OA\Property(property: 'first_name', type: 'string', example: 'Jean'),
        new OA\Property(property: 'last_name', type: 'string', example: 'Dupont'),
        new OA\Property(property: 'email', type: 'string', format: 'email', example: 'jean.dupont@example.com'),
        new OA\Property(property: 'city', type: 'string', nullable: true, example: 'Paris'),
        new OA\Property(property: 'birth_date', type: 'string', format: 'date', nullable: true),
        new OA\Property(property: 'id_role', type: 'integer', example: 2),
        new OA\Property(property: 'id_user_state', type: 'integer', example: 1),
        new OA\Property(property: 'created_at', type: 'string', format: 'date-time'),
    ]
)]
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $table = 'users';
    protected $primaryKey = 'id_user';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'password',
        'city',
        'birth_date',
        'id_role',
        'id_user_state',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'birth_date' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'password'   => 'hashed',
    ];

    // ── Relations ─────────────────────────────────────────────────────────────

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class, 'id_role', 'id_role');
    }

    public function userState(): BelongsTo
    {
        return $this->belongsTo(UserState::class, 'id_user_state', 'id_user_state');
    }

    public function emotionJournalEntries(): HasMany
    {
        return $this->hasMany(EmotionJournalEntry::class, 'id_user', 'id_user');
    }

    // ── Helpers rôles ─────────────────────────────────────────────────────────

    public function isAdmin(): bool
    {
        return $this->role?->name === Role::ADMIN;
    }

    public function isUser(): bool
    {
        return $this->role?->name === Role::USER;
    }

    public function isActive(): bool
    {
        return $this->userState?->name === UserState::ACTIVE;
    }

    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }
}
