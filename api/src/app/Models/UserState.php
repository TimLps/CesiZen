<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class UserState extends Model
{
    use HasFactory;

    public const ACTIVE   = 'active';
    public const INACTIVE = 'inactive';
    public const BANNED   = 'banned';

    protected $table = 'user_states';
    protected $primaryKey = 'id_user_state';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = ['name', 'label'];

    public function users(): HasMany
    {
        return $this->hasMany(User::class, 'id_user_state', 'id_user_state');
    }
}
