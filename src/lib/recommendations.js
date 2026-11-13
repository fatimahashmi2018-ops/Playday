export function recommendWorkouts(workouts, preferences) {

  const {
    mood,
    duration,
    experience,
    equipment,
  } = preferences;

  const results = workouts.map((workout) => {

    let score = 0;

    // Mood match
    if (mood && workout.mood_tags.includes(mood)) {
      score += 5;
    }

    // Duration match
    if (workout.duration_minutes <= duration) {
      score += 3;
    } else {
      score -= 3;
    }

    // Experience match
    if (workout.difficulty === experience) {
      score += 2;
    }

    // Equipment match
    const needsEquipment =
      workout.equipment.filter((item) => item !== "none");

    const hasRequiredEquipment =
      needsEquipment.every((item) =>
        equipment.includes(item)
      );

    if (hasRequiredEquipment) {
      score += 3;
    } else {
      score -= 5;
    }

    // Beginner-friendly bonus
    if (workout.difficulty === "beginner") {
      score += 1;
    }

    return {
      ...workout,
      recommendationScore: score,
    };

  });

  return results
    .filter((workout) => workout.recommendationScore > 0)
    .sort((a, b) =>
      b.recommendationScore - a.recommendationScore
    );

}