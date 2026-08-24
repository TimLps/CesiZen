<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'EmotionCategory',
    title: 'Catégorie d\'émotion (niveau 1)',
    properties: [
        new OA\Property(property: 'id_emotion_category', type: 'integer', example: 1),
        new OA\Property(property: 'name', type: 'string', example: 'Joie'),
        new OA\Property(property: 'feeling_label', type: 'string', example: 'joyeux', description: 'Forme adjectivale pour "Vous vous sentez ..."'),
        new OA\Property(property: 'color_hex', type: 'string', example: '#B0E0E6'),
        new OA\Property(property: 'icon', type: 'string', nullable: true, example: 'sentiment_satisfied'),
        new OA\Property(property: 'sort_order', type: 'integer', example: 1),
        new OA\Property(property: 'is_active', type: 'boolean', example: true),
    ]
)]
class EmotionCategory extends Model
{
    use HasFactory;

    protected $table = 'emotion_categories';
    protected $primaryKey = 'id_emotion_category';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'name',
        'feeling_label',
        'color_hex',
        'icon',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'is_active'  => 'boolean',
        'sort_order' => 'integer',
    ];

    public function emotions(): HasMany
    {
        return $this->hasMany(Emotion::class, 'id_emotion_category', 'id_emotion_category');
    }
}
