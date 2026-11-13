
-- =========================================
-- PLAYDAY SAMPLE WORKOUTS
-- =========================================

insert into public.workouts (
  title,
  slug,
  description,
  category,
  mood_tags,
  duration_minutes,
  difficulty,
  equipment,
  image_path,
  xp_reward,
  is_featured
)
values

(
  'Desk Potato Rescue',
  'desk-potato-rescue',
  'A tiny movement reset for days spent sitting at your desk.',
  'stretching',
  array['low-energy', 'stressed', 'need-a-reset'],
  5,
  'beginner',
  array['none'],
  '/images/workout-desk-potato.webp',
  20,
  true
),

(
  'Main Character Walk',
  'main-character-walk',
  'Put on your favourite playlist and take a little walking adventure.',
  'walking',
  array['playful', 'energetic'],
  10,
  'beginner',
  array['none'],
  '/images/workout-main-character.webp',
  25,
  true
),

(
  'Lazy Girl Pilates Club',
  'lazy-girl-pilates',
  'A gentle beginner-friendly Pilates-inspired movement session.',
  'pilates',
  array['low-energy', 'playful', 'need-a-reset'],
  10,
  'beginner',
  array['mat'],
  '/images/workout-lazy-pilates.webp',
  25,
  true
),

(
  'Kitchen Dance Party',
  'kitchen-dance-party',
  'Dance around and enjoy a little burst of movement.',
  'dance',
  array['playful', 'energetic'],
  5,
  'beginner',
  array['none'],
  '/images/workout-dance-party.webp',
  20,
  true
),

(
  'Princess Posture Reset',
  'princess-posture-reset',
  'A gentle neck, shoulder and upper-back mobility break.',
  'mobility',
  array['low-energy', 'stressed', 'need-a-reset'],
  5,
  'beginner',
  array['none'],
  '/images/workout-posture-reset.webp',
  20,
  false
),

(
  'Sunday Reset',
  'sunday-reset',
  'A relaxing full-body stretch to wind down and move comfortably.',
  'stretching',
  array['low-energy', 'need-a-reset'],
  15,
  'beginner',
  array['mat'],
  '/images/workout-sunday-reset.webp',
  30,
  true
);

-- =========================================
-- ACHIEVEMENTS
-- =========================================

insert into public.achievements (
  slug,
  name,
  description,
  icon_path,
  xp_reward
)
values

(
  'first-step',
  'First Little Win',
  'Complete your first workout.',
  '/images/achievement-first-workout.webp',
  20
),

(
  'five-workouts',
  'Getting Into It',
  'Complete five workouts.',
  '/images/achievement-five-workouts.webp',
  30
),

(
  'three-day-streak',
  'Three Days of Showing Up',
  'Move on three consecutive days.',
  '/images/achievement-week-streak.webp',
  40
),

(
  'ten-workouts',
  'Movement Bestie',
  'Complete ten workouts.',
  '/images/achievement-ten-workouts.webp',
  50
);
