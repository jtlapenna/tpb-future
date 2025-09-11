"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { NAV } from "@/config/nav";

export function KioskNav() {
  const pathname = usePathname();

  return (
    <ul style={{
      margin: '0 -15px',
      width: 'auto',
      display: 'flex',
      flexWrap: 'wrap',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      listStyle: 'none',
      padding: 0,
      gap: '0'
    }}>
      {NAV.map((link, index) => {
        const active = pathname === link.path;
        return (
          <li key={link.path} className="element" style={{
            margin: '0 15px 30px',
            width: index === 2 ? 'calc(100% - 30px)' : 'calc(50% - 30px)',
            height: '200px',
            background: '#0ea5e9',
            borderRadius: '30px',
            position: 'relative',
            flex: index === 2 ? '0 0 calc(100% - 30px)' : '0 0 calc(50% - 30px)'
          }}>
            <Link
              href={link.path}
              className={`link ${active ? 'router-link-exact-active' : ''}`}
              style={{
                display: 'block',
                width: '100%',
                height: '100%',
                position: 'relative',
                borderRadius: '20px',
                color: '#ffffff',
                textDecoration: 'none',
                background: 'transparent'
              }}
            >
              <div className="inner">
                <div className="number">
                  <div className="number__text">
                    {String(index + 1).padStart(2, '0')}
                  </div>
                  <div className="number__line"></div>
                </div>

                <div className="label">
                  {link.title}
                </div>

                <div className="arrow">
                  <div className="arrow__line"></div>
                </div>
              </div>
            </Link>
          </li>
        );
      })}
    </ul>
  );
}
