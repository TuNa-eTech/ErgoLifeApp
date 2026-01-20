import { Link } from "react-router";

export function Footer() {
  return (
    <footer className="w-full bg-white border-t border-gray-100 mt-auto">
      <div className="mx-auto max-w-[1280px] px-6 py-8 md:py-12">
        <div className="flex flex-col md:flex-row justify-between items-center gap-6">
          <Link to="/" className="flex items-center gap-2">
            <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-primary text-white">
              <span className="material-symbols-outlined text-sm">
                fitness_center
              </span>
            </div>
            <span className="text-lg font-bold text-navy font-display">
              ErgoLife
            </span>
          </Link>
          <div className="flex gap-6 text-sm text-navy-light">
            <Link className="hover:text-primary transition-colors" to="/privacy">
              Privacy
            </Link>
            <Link className="hover:text-primary transition-colors" to="/terms">
              Terms
            </Link>
            <Link className="hover:text-primary transition-colors" to="/support">
              Support
            </Link>
          </div>
          <div className="text-sm text-gray-400">
            © 2026 ErgoLife Inc. All rights reserved.
          </div>
        </div>
      </div>
    </footer>
  );
}
