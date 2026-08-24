<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'Emotion',
    title: 'Émotion (niveau 2)',
    properties: [
        new OA\Property(property: 'id_emotion', type: 'integer', example: 1),
        new OA\Property(property: 'id_emotion_category', type: 'integer', example: 1),
        new OA\Property(property: 'name', type: 'string', example: 'Enchantement'),
        new OA\Property(property: 'feeling_label', type: 'string', example: 'enchanté', description: 'Forme adjectivale pour "Vous vous sentez ..."'),
        new OA\Property(property: 'is_active', type: 'boolean', example: true),
        new OA\Property(property: 'category', ref: '#/components/schemas/EmotionCategory'),
    ]
)]
class Emotion extends Model
{
    use HasFactory;

    protected $table = 'emotions';
    protected $primaryKey = 'id_emotion';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'id_emotion_category',
        'name',
        'feeling_label',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(EmotionCategory::class, 'id_emotion_category', 'id_emotion_category');
    }

    public function journalEntries(): HasMany
    {
        return $this->hasMany(EmotionJournalEntry::class, 'id_emotion', 'id_emotion');
    }
}
