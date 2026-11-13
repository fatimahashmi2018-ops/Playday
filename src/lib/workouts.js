import { createClient } from "./supabase";

export async function getWorkouts({ request, cookies }) {

  const supabase = createClient({
    request,
    cookies,
  });

  const { data, error } = await supabase
    .from("workouts")
    .select("*")
    .eq("is_published", true)
    .order("is_featured", { ascending: false })
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Could not load workouts:", error.message);

    return {
      workouts: [],
      error: "We couldn't load the workouts. Please try again.",
    };
  }

  return {
    workouts: data ?? [],
    error: null,
  };
}