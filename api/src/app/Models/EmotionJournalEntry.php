<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'EmotionJournalEntry',
    title: 'Entrée du journal d\'émotions',
    properties: [
        new OA\Property(property: 'id_journal_entry', type: 'integer', example: 1),
        new OA\Property(property: 'id_user', type: 'integer', example: 1),
        new OA\Property(property: 'id_emotion', type: 'integer', example: 3),
        new OA\Property(property: 'entry_date', type: 'string', format: 'date', example: '2026-01-21'),
        new OA\Property(property: 'felt_at', type: 'string', format: 'date-time', nullable: true, example: '2026-01-21T14:35:00Z', description: 'Moment réel du ressenti (created_at - durée déclarée)'),
        new OA\Property(property: 'note', type: 'string', nullable: true, example: 'Belle journée ensoleillée'),
        new OA\Property(property: 'created_at', type: 'string', format: 'date-time', example: '2026-01-21T14:40:00Z'),
        new OA\Property(property: 'emotion', ref: '#/components/schemas/Emotion'),
    ]
)]
class EmotionJournalEntry extends Model
{
    use HasFactory;

    protected $table = 'emotion_journal_entries';
    protected $primaryKey = 'id_journal_entry';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'id_user',
        'id_emotion',
        'entry_date',
        'felt_at',
        'note',
    ];

    protected $casts = [
        'entry_date' => 'date',
        'felt_at'    => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function emotion(): BelongsTo
    {
        return $this->belongsTo(Emotion::class, 'id_emotion', 'id_emotion');
    }
}
