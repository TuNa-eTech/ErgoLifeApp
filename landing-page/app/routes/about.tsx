import type { Route } from "./+types/about";
import { Navbar } from "~/components/Navbar";
import { Footer } from "~/components/Footer";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "About Us | ErgoLife" },
    {
      name: "description",
      content: "Learn more about the team and mission behind ErgoLife.",
    },
  ];
}

export default function About() {
  return (
    <div className="bg-background-light text-navy antialiased min-h-screen flex flex-col font-body">
      <Navbar />

      <main className="flex-grow w-full px-6 py-6 md:py-10">
        <div className="mx-auto max-w-[1000px] space-y-8">
          {/* Header Section */}
          <div className="clay-card p-10 md:p-14 text-center">
            <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-navy font-display mb-6">
              Our Mission
            </h1>
            <p className="text-xl text-navy-light font-medium max-w-2xl mx-auto leading-relaxed">
              To transform the mundane into the meaningful by gamifying daily
              life, making productivity fun, and building healthier habits for
              everyone.
            </p>
          </div>

          {/* Story Section */}
          <div className="grid md:grid-cols-2 gap-8">
            <div className="clay-card p-8 flex flex-col justify-center">
              <h2 className="text-2xl font-bold text-navy font-display mb-4">
                Why ErgoLife?
              </h2>
              <p className="text-navy-light leading-relaxed mb-4">
                We observed that two of the hardest things to maintain consistently
                are a clean home and a fitness routine. They both feel like
                chores.
              </p>
              <p className="text-navy-light leading-relaxed">
                ErgoLife bridges this gap. We believe that vacuuming can be your
                cardio, and organizing can be a game. By tracking the physical
                effort of your daily tasks, we help you realize that every move
                counts.
              </p>
            </div>
            <div className="clay-card p-8 min-h-[300px] bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center relative overflow-hidden">
              <div className="absolute inset-0 flex items-center justify-center opacity-10">
                 <span className="material-symbols-outlined text-[200px] text-primary">
                    fitness_center
                 </span>
              </div>
               <div className="relative z-10 text-center">
                  <span className="text-6xl font-extrabold text-primary font-display block mb-2">1M+</span>
                  <span className="text-lg font-bold text-navy-light">Chores Completed</span>
               </div>
            </div>
          </div>

          {/* Team/Values Section */}
          <div className="clay-card p-8 md:p-12">
            <h2 className="text-3xl font-bold text-navy font-display mb-8 text-center">
              What Drives Us
            </h2>
            <div className="grid md:grid-cols-3 gap-8">
              <div className="text-center">
                <div className="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center mx-auto mb-4 text-blue-600">
                  <span className="material-symbols-outlined text-3xl">
                    joystick
                  </span>
                </div>
                <h3 className="text-lg font-bold text-navy mb-2">Gamification</h3>
                <p className="text-sm text-navy-light">
                  Making work feel like play is the key to long-term consistency.
                </p>
              </div>
              <div className="text-center">
                <div className="w-16 h-16 bg-green-100 rounded-2xl flex items-center justify-center mx-auto mb-4 text-green-600">
                   <span className="material-symbols-outlined text-3xl">
                    health_and_safety
                  </span>
                </div>
                <h3 className="text-lg font-bold text-navy mb-2">Health</h3>
                <p className="text-sm text-navy-light">
                  Physical and mental well-being are at the core of everything we do.
                </p>
              </div>
              <div className="text-center">
                <div className="w-16 h-16 bg-purple-100 rounded-2xl flex items-center justify-center mx-auto mb-4 text-purple-600">
                   <span className="material-symbols-outlined text-3xl">
                    groups
                  </span>
                </div>
                <h3 className="text-lg font-bold text-navy mb-2">Community</h3>
                <p className="text-sm text-navy-light">
                  We are stronger together. Competition and support drive progress.
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
