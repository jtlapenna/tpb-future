"use client";
import { useEffect, useRef } from 'react';

interface LottieAnimationProps {
  path: string;
  autoplay?: boolean;
  loop?: boolean;
  className?: string;
  style?: React.CSSProperties;
}

export function LottieAnimation({ 
  path, 
  autoplay = true, 
  loop = true, 
  className = "",
  style = {}
}: LottieAnimationProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // For now, we'll create a simple placeholder
    // In a real implementation, you'd load the Lottie library here
    if (containerRef.current) {
      containerRef.current.innerHTML = `
        <div style="
          width: 100%;
          height: 100%;
          background: linear-gradient(45deg, #00c394, #00a085);
          border-radius: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-size: 18px;
          font-weight: bold;
          text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        ">
          <div style="text-align: center;">
            <div style="font-size: 48px; margin-bottom: 10px;">👋</div>
            <div>RFID Animation</div>
            <div style="font-size: 12px; opacity: 0.8; margin-top: 5px;">${path}</div>
          </div>
        </div>
      `;
    }
  }, [path]);

  return (
    <div 
      ref={containerRef}
      className={className}
      style={style}
    />
  );
}
