export function getWeeklyActivity(completions = []) {

  const days = [];

  const today = new Date();

  for (let i = 6; i >= 0; i--) {

    const date = new Date(today);

    date.setDate(today.getDate() - i);

    const dateKey = date.toLocaleDateString("en-CA");

    const minutes = completions
      .filter((item) => {

        const completionDate =
          new Date(item.completed_at)
            .toLocaleDateString("en-CA");

        return completionDate === dateKey;

      })
      .reduce(
        (total, item) =>
          total + item.duration_seconds / 60,
        0
      );

    days.push({
      date: dateKey,
      label: date.toLocaleDateString("en", {
        weekday: "short",
      }),
      minutes: Math.round(minutes),
    });

  }

  return days;

}