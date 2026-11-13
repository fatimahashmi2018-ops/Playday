import { defineAction } from "astro:actions";
import { z } from "astro/zod";

import { createClient } from "../lib/supabase";



export const server = {
      // =====================================
  // UPDATE PROFILE
  // =====================================

  updateProfile: defineAction({

    input: z.object({

      display_name: z.string().trim().min(2).max(40),

      preferred_duration: z.number().int().refine(
        (value) => [3, 5, 10, 15].includes(value)
      ),

      experience: z.enum([
        "beginner",
        "intermediate",
        "advanced",
      ]),

      equipment: z.array(
        z.enum(["none", "mat"])
      ).max(2),

    }),

    handler: async (input, context) => {

      const supabase = createClient({
        request: context.request,
        cookies: context.cookies,
      });

      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        return {
          success: false,
          message: "Please sign in.",
        };
      }

      const { error } = await supabase
        .from("profiles")
        .update({
          display_name: input.display_name,
          preferred_duration: input.preferred_duration,
          experience: input.experience,
          equipment: input.equipment,
        })
        .eq("id", user.id);

      if (error) {
        return {
          success: false,
          message: "Unable to update your profile.",
        };
      }

      return {
        success: true,
      };

    },

  }),
      // =====================================
  // TOGGLE FAVORITE
  // =====================================

  toggleFavorite: defineAction({

    input: z.object({

      workout_id: z.string().uuid(),

    }),

    handler: async (input, context) => {

      const supabase = createClient({
        request: context.request,
        cookies: context.cookies,
      });

      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) {
        return {
          success: false,
          message: "Please sign in first.",
        };
      }

      const { data: existing } = await supabase
        .from("favorites")
        .select("id")
        .eq("user_id", user.id)
        .eq("workout_id", input.workout_id)
        .maybeSingle();

      if (existing) {

        const { error } = await supabase
          .from("favorites")
          .delete()
          .eq("id", existing.id);

        if (error) {
          return {
            success: false,
            message: "Couldn't remove favourite.",
          };
        }

        return {
          success: true,
          favorite: false,
        };

      }

      const { error } = await supabase
        .from("favorites")
        .insert({
          user_id: user.id,
          workout_id: input.workout_id,
        });

      if (error) {
        return {
          success: false,
          message: "Couldn't save favourite.",
        };
      }

      return {
        success: true,
        favorite: true,
      };

    },

  }),
      // =====================================
  // COMPLETE WORKOUT
  // =====================================

  completeWorkout: defineAction({

    input: z.object({

      workout_id: z.string().uuid(),

      duration_seconds: z.number().int().min(30).max(14400),

    }),

    handler: async (input, context) => {

      const supabase = createClient({
        request: context.request,
        cookies: context.cookies,
      });

      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();

      if (authError || !user) {

        return {
          success: false,
          message: "Please sign in to save your workout.",
        };

      }

      const { data, error } = await supabase.rpc(
        "complete_workout",
        {
          p_workout_id: input.workout_id,
          p_duration_seconds: input.duration_seconds,
        }
      );

      if (error) {

        return {
          success: false,
          message: "We couldn't save your workout. Please try again.",
        };

      }

      return {
        success: true,
        result: data,
      };

    },

  }),

  // =====================================
  // SIGN UP
  // =====================================

  signUp: defineAction({

    accept: "form",

    input: z.object({
      display_name: z.string().trim().min(2).max(40),

      email: z.string().trim().email(),

      password: z.string().min(8).max(72),
    }),

    handler: async (input, context) => {

      const supabase = createClient({
        request: context.request,
        cookies: context.cookies,
      });

      const { error } = await supabase.auth.signUp({

        email: input.email,

        password: input.password,

        options: {
          data: {
            display_name: input.display_name,
          },

          emailRedirectTo: new URL(
            "/auth/callback",
            context.request.url
          ).toString(),
        },

      });

      if (error) {
        return {
          success: false,
          message: error.message,
        };
      }

      return {
        success: true,
        message: "Check your email to confirm your account!",
      };
    },

  }),

  // =====================================
  // SIGN IN
  // =====================================

  signIn: defineAction({

    accept: "form",

    input: z.object({

      email: z.string().trim().email(),

      password: z.string().min(1).max(72),

    }),

    handler: async (input, context) => {

      const supabase = createClient({
        request: context.request,
        cookies: context.cookies,
      });

      const { error } =
        await supabase.auth.signInWithPassword({

          email: input.email,

          password: input.password,

        });

      if (error) {
        return {
          success: false,
          message: "Unable to sign in. Check your details and try again.",
        };
      }

      return {
        success: true,
        message: "Welcome back!",
      };
    },

  }),

  // =====================================
  // SIGN OUT
  // =====================================

  signOut: defineAction({

    handler: async (_, context) => {

      const supabase = createClient({
        request: context.request,
        cookies: context.cookies,
      });

      const { error } = await supabase.auth.signOut();

      if (error) {
        return {
          success: false,
          message: "Could not sign out.",
        };
      }

      return {
        success: true,
      };
    },

  }),

};