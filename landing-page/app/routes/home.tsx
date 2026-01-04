import type { Route } from "./+types/home";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "ErgoLife - Turn Chores into Gains" },
    {
      name: "description",
      content:
        "The first app that combines home management with fitness tracking.",
    },
  ];
}

export default function Home() {
  return (
    <div className="bg-background-light text-navy antialiased min-h-screen flex flex-col font-body">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 w-full px-6 py-4">
        <div className="mx-auto max-w-[1280px]">
          <div className="clay-card !rounded-2xl px-6 py-3 flex items-center justify-between border border-white/50 backdrop-blur-md bg-white/80">
            <div className="flex items-center gap-3">
              <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-primary text-white">
                <span className="material-symbols-outlined">fitness_center</span>
              </div>
              <span className="text-xl font-bold tracking-tight text-navy">
                ErgoLife
              </span>
            </div>
            <div className="hidden md:flex items-center gap-8">
              <a
                className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
                href="#"
              >
                Features
              </a>
              <a
                className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
                href="#"
              >
                Rewards
              </a>
              <a
                className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
                href="#"
              >
                Community
              </a>
              <a
                className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
                href="#"
              >
                About
              </a>
            </div>
            <div className="flex items-center gap-3">
              <button className="hidden md:flex text-sm font-semibold text-navy hover:text-primary transition-colors px-4 py-2 cursor-pointer">
                Log In
              </button>
              <button className="bg-primary hover:bg-primary-hover text-white text-sm font-bold py-2.5 px-5 rounded-xl transition-all shadow-lg shadow-primary/20 flex items-center gap-2 cursor-pointer">
                <span>Get App</span>
                <span className="material-symbols-outlined text-[18px]">
                  arrow_forward
                </span>
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content: Bento Grid Layout */}
      <main className="flex-grow w-full px-6 py-6 md:py-10">
        <div className="mx-auto max-w-[1280px]">
          {/* Grid Container */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 auto-rows-[minmax(180px,auto)]">
            {/* 1. Hero Block (Large, spans full width or large portion) */}
            <div className="col-span-1 md:col-span-8 lg:col-span-8 row-span-2 clay-card p-8 md:p-12 flex flex-col justify-center relative overflow-hidden group">
              <div className="relative z-10 max-w-xl flex flex-col gap-6">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 w-fit">
                  <span className="material-symbols-outlined text-primary text-sm">
                    bolt
                  </span>
                  <span className="text-xs font-bold text-primary uppercase tracking-wider">
                    New Challenge Live
                  </span>
                </div>
                <h1 className="text-4xl md:text-5xl lg:text-6xl font-extrabold leading-[1.1] text-navy font-display">
                  Turn Chores into <br />{" "}
                  <span className="text-gradient">Fitness Gains.</span>
                </h1>
                <p className="text-lg text-navy-light font-medium leading-relaxed max-w-md">
                  The first app that combines home management with fitness
                  tracking. Get fit while getting things done.
                </p>
                <div className="flex flex-wrap gap-4 pt-2">
                  <button className="bg-primary hover:bg-primary-hover text-white text-base font-bold py-4 px-8 rounded-2xl transition-all shadow-xl shadow-primary/25 hover:scale-105 active:scale-95 flex items-center gap-2 cursor-pointer">
                    Start Challenge
                  </button>
                  <button className="bg-white border border-gray-200 hover:border-primary/30 text-navy text-base font-bold py-4 px-8 rounded-2xl transition-all hover:bg-gray-50 flex items-center gap-2 cursor-pointer">
                    <span className="material-symbols-outlined">
                      play_circle
                    </span>
                    Watch Demo
                  </button>
                </div>
              </div>
              {/* Decorative/Illustration Area */}
              <div className="absolute right-[-20px] bottom-[-40px] md:right-0 md:bottom-0 w-[300px] md:w-[450px] lg:w-[500px] h-full pointer-events-none opacity-90 transition-transform duration-500 group-hover:scale-105">
                <div
                  className="w-full h-full bg-contain bg-right-bottom bg-no-repeat"
                  data-alt="3D energetic person holding a vacuum cleaner like a trophy"
                  style={{
                    backgroundImage: "url('/images/hero-vacuum.png')",
                  }}
                ></div>
                {/* Gradient overlay to blend image into card if needed */}
                <div className="absolute inset-0 bg-gradient-to-l from-transparent via-transparent to-white/60 md:to-white/20"></div>
              </div>
            </div>

            {/* 2. Stats Block (Top Right) */}
            <div className="col-span-1 md:col-span-4 row-span-1 clay-card p-6 flex flex-col justify-between bg-navy text-white relative overflow-hidden">
              <div className="absolute top-0 right-0 p-4 opacity-10">
                <span className="material-symbols-outlined text-[120px]">
                  timer
                </span>
              </div>
              <div className="relative z-10">
                <h3 className="text-lg font-medium text-gray-300 font-display">
                  Calories Burned Today
                </h3>
                <div className="flex items-baseline gap-2 mt-2">
                  <span className="text-5xl font-bold font-display">420</span>
                  <span className="text-xl text-primary font-bold">kcal</span>
                </div>
              </div>
              <div className="mt-4 relative z-10">
                <div className="w-full bg-white/10 rounded-full h-2 mb-2">
                  <div
                    className="bg-primary h-2 rounded-full"
                    style={{ width: "75%" }}
                  ></div>
                </div>
                <p className="text-xs text-gray-400">
                  75% of daily goal achieved
                </p>
              </div>
            </div>

            {/* 3. Feature: Calorie Comparator (Middle Right) */}
            <div className="col-span-1 md:col-span-4 row-span-1 clay-card p-6 flex flex-col justify-center group">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 bg-blue-100 text-blue-600 rounded-lg">
                  <span className="material-symbols-outlined">
                    compare_arrows
                  </span>
                </div>
                <h3 className="text-lg font-bold text-navy font-display">
                  Calorie Compare
                </h3>
              </div>
              <div className="flex items-center justify-between text-center">
                <div className="flex flex-col items-center gap-2">
                  <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center text-2xl">
                    🧹
                  </div>
                  <span className="text-xs font-bold text-navy-light">
                    Vacuuming
                  </span>
                  <span className="text-sm font-bold text-navy">150 cal</span>
                </div>
                <div className="text-gray-300 font-bold text-xl">=</div>
                <div className="flex flex-col items-center gap-2">
                  <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-2xl">
                    🏃
                  </div>
                  <span className="text-xs font-bold text-navy-light">
                    15m Run
                  </span>
                  <span className="text-sm font-bold text-navy">150 cal</span>
                </div>
              </div>
            </div>

            {/* 4. Feature: Reward Shop (Bottom Left - Wide) */}
            <div className="col-span-1 md:col-span-6 lg:col-span-4 row-span-1 clay-card p-6 flex flex-col relative overflow-hidden group">
              <div className="flex justify-between items-start mb-2 relative z-10">
                <div>
                  <h3 className="text-xl font-bold text-navy font-display">
                    Reward Shop
                  </h3>
                  <p className="text-sm text-navy-light mt-1">
                    Redeem sweat for treats.
                  </p>
                </div>
                <div className="bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full text-xs font-bold flex items-center gap-1">
                  <span className="material-symbols-outlined text-sm">stars</span>
                  2,450 pts
                </div>
              </div>
              <div className="mt-auto grid grid-cols-3 gap-3 relative z-10 pt-4">
                <div className="bg-[#F9FAFB] rounded-xl p-2 flex flex-col items-center gap-1 border border-gray-100 hover:border-primary/50 transition-colors cursor-pointer">
                  <img
                    alt="Red sneaker shoe"
                    className="w-10 h-10 object-contain"
                    src="/images/reward-gear.png"
                  />
                  <span className="text-[10px] font-bold text-navy">Gear</span>
                </div>
                <div className="bg-[#F9FAFB] rounded-xl p-2 flex flex-col items-center gap-1 border border-gray-100 hover:border-primary/50 transition-colors cursor-pointer">
                  <img
                    alt="Mobile phone displaying app interface"
                    className="w-10 h-10 object-contain"
                    src="/images/reward-premium.png"
                  />
                  <span className="text-[10px] font-bold text-navy">
                    Premium
                  </span>
                </div>
                <div className="bg-[#F9FAFB] rounded-xl p-2 flex flex-col items-center gap-1 border border-gray-100 hover:border-primary/50 transition-colors cursor-pointer">
                  <img
                    alt="Healthy green salad bowl"
                    className="w-10 h-10 object-contain"
                    src="/images/reward-food.png"
                  />
                  <span className="text-[10px] font-bold text-navy">Food</span>
                </div>
              </div>
            </div>

            {/* 5. Feature: Daily Streak (Bottom Middle) */}
            <div className="col-span-1 md:col-span-6 lg:col-span-4 row-span-1 clay-card p-6 flex items-center gap-6 group">
              <div className="relative w-24 h-24 flex-shrink-0">
                <svg
                  className="w-full h-full transform -rotate-90"
                  viewBox="0 0 36 36"
                >
                  <path
                    className="text-gray-100"
                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="3"
                  ></path>
                  <path
                    className="text-primary transition-all duration-1000 ease-out"
                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                    fill="none"
                    stroke="currentColor"
                    strokeDasharray="85, 100"
                    strokeWidth="3"
                  ></path>
                </svg>
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-center">
                  <span className="block text-2xl font-bold text-navy font-display">
                    7
                  </span>
                  <span className="block text-[10px] font-medium text-navy-light uppercase">
                    Days
                  </span>
                </div>
              </div>
              <div className="flex flex-col gap-2">
                <h3 className="text-xl font-bold text-navy font-display">
                  Daily Streak
                </h3>
                <p className="text-sm text-navy-light">
                  Keep it up! Complete today's laundry mission to reach day 8.
                </p>
                <button className="text-primary text-sm font-bold flex items-center gap-1 hover:gap-2 transition-all mt-1 cursor-pointer">
                  Check Missions{" "}
                  <span className="material-symbols-outlined text-sm">
                    arrow_forward
                  </span>
                </button>
              </div>
            </div>

            {/* 6. Feature: Community (Bottom Right) */}
            <div className="col-span-1 md:col-span-12 lg:col-span-4 row-span-1 clay-card p-6 flex flex-col justify-between bg-gradient-to-br from-white to-[#F2F4F7]">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-bold text-navy font-display">
                  Community
                </h3>
                <div className="flex -space-x-2">
                  <img
                    alt="Portrait of a smiling young woman"
                    className="w-8 h-8 rounded-full border-2 border-white object-cover"
                    src="/images/user-1.png"
                  />
                  <img
                    alt="Portrait of a young man"
                    className="w-8 h-8 rounded-full border-2 border-white object-cover"
                    src="/images/user-2.png"
                  />
                  <img
                    alt="Portrait of a smiling man with glasses"
                    className="w-8 h-8 rounded-full border-2 border-white object-cover"
                    src="/images/user-3.png"
                  />
                  <div className="w-8 h-8 rounded-full border-2 border-white bg-gray-100 flex items-center justify-center text-[10px] font-bold text-navy-light">
                    +2k
                  </div>
                </div>
              </div>
              <div className="bg-white p-3 rounded-xl border border-gray-100 shadow-sm">
                <div className="flex gap-3">
                  <div className="w-8 h-8 rounded-full bg-blue-50 text-blue-500 flex items-center justify-center flex-shrink-0">
                    <span className="material-symbols-outlined text-sm">
                      thumb_up
                    </span>
                  </div>
                  <div>
                    <p className="text-xs text-navy font-semibold">
                      <span className="text-primary">Sarah</span> just finished
                      "Kitchen Deep Clean"
                    </p>
                    <p className="text-[10px] text-gray-400 mt-1">
                      2 mins ago
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Simple Footer */}
      <footer className="w-full bg-white border-t border-gray-100 mt-auto">
        <div className="mx-auto max-w-[1280px] px-6 py-8 md:py-12">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="flex items-center gap-2">
              <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-primary text-white">
                <span className="material-symbols-outlined text-sm">
                  fitness_center
                </span>
              </div>
              <span className="text-lg font-bold text-navy font-display">
                ErgoLife
              </span>
            </div>
            <div className="flex gap-6 text-sm text-navy-light">
              <a className="hover:text-primary transition-colors" href="#">
                Privacy
              </a>
              <a className="hover:text-primary transition-colors" href="#">
                Terms
              </a>
              <a className="hover:text-primary transition-colors" href="#">
                Support
              </a>
            </div>
            <div className="text-sm text-gray-400">
              © 2023 ErgoLife Inc. All rights reserved.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
