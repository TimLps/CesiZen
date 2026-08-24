<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'Role',
    title: 'Rôle',
    description: 'Rôle attribué à un utilisateur',
    properties: [
        new OA\Property(property: 'id_role', type: 'integer', example: 1),
        new OA\Property(property: 'name', type: 'string', example: 'admin'),
        new OA\Property(property: 'label', type: 'string', example: 'Administrateur'),
    ]
)]
class Role extends Model
{
    use HasFactory;

    public const ADMIN = 'admin';
    public const USER  = 'user';

    protected $table = 'roles';
    protected $primaryKey = 'id_role';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = ['name', 'label'];

    public function users(): HasMany
    {
        return $this->hasMany(User::class, 'id_role', 'id_role');
    }
}
