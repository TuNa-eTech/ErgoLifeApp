import { Link } from "react-router";

export function Navbar() {
  return (
    <nav className="sticky top-0 z-50 w-full px-6 py-4">
      <div className="mx-auto max-w-[1280px]">
        <div className="clay-card !rounded-2xl px-6 py-3 flex items-center justify-between border border-white/50 backdrop-blur-md bg-white/80">
          <Link to="/" className="flex items-center gap-3">
            <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-primary text-white">
              <span className="material-symbols-outlined">fitness_center</span>
            </div>
            <span className="text-xl font-bold tracking-tight text-navy">
              ErgoLife
            </span>
          </Link>
          <div className="hidden md:flex items-center gap-8">
            <a
              className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
              href="/#features"
            >
              Features
            </a>
            <a
              className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
              href="/#rewards"
            >
              Rewards
            </a>
            <a
              className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
              href="/#community"
            >
              Community
            </a>
            <Link
              className="text-sm font-medium text-navy-light hover:text-primary transition-colors"
              to="/about"
            >
              About
            </Link>
          </div>
          <div className="flex items-center gap-3">
            <a
              href="https://apps.apple.com"
              target="_blank"
              rel="noreferrer"
              className="bg-primary hover:bg-primary-hover text-white text-sm font-bold py-2.5 px-5 rounded-xl transition-all shadow-lg shadow-primary/20 flex items-center gap-2 cursor-pointer"
            >
              <span>Download App</span>
              <span className="material-symbols-outlined text-[18px]">
                download
              </span>
            </a>
          </div>
        </div>
      </div>
    </nav>
  );
}
