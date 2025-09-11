"use client";
import dynamic from "next/dynamic";
import { LottieAnimation } from "@/components/LottieAnimation";

const KioskNav = dynamic(() => import("@/components/KioskNav").then(mod => mod.KioskNav), { ssr: false });

interface HomeScreenProps {
  // Configuration props - in real app these would come from context/API
  rfidEnabled?: boolean;
  customWelcomeMessage?: string | null;
  enabledContinuousCart?: boolean;
  storeLogoUrl?: string;
  storeLogoType?: 'horizontal' | 'vertical' | 'square' | 'rectangle';
}

export function HomeScreen({
  rfidEnabled = false,
  customWelcomeMessage = null,
  enabledContinuousCart = false,
  storeLogoUrl = "/static/img/default-store-logo.svg",
  storeLogoType = 'horizontal'
}: HomeScreenProps) {
  // Determine welcome message based on configuration - exact logic from legacy
  const getWelcomeMessage = () => {
    if (rfidEnabled) {
      return 'Place a \nfeatured item \non the stand.';
    } else {
      if (customWelcomeMessage) {
        return customWelcomeMessage;
      } else {
        return 'Browse our catalogue \nto see what we have \nin stock!';
      }
    }
  };

  const welcomeMessage = getWelcomeMessage();
  const showWelcomeText = !rfidEnabled; // Simplified logic based on audit

  return (
    <div id="screen-home-default" className="screen screen--home">
      {/* Store Logo - matches legacy structure exactly */}
      <img
        className={`store-logo store-logo--${storeLogoType}`}
        src={storeLogoUrl}
        alt="Store Logo"
      />

      {/* Animation Placeholder - replaces welcome text */}
      <div className="animation-placeholder">
        ANIMATION PLACEHOLDER
      </div>

      {/* RFID Animation - conditional rendering with exact positioning */}
      {rfidEnabled && (
        <div className="illustration">
          <LottieAnimation
            path="howto-notext"
            autoplay={true}
            loop={true}
            className="lottie-container"
          />
        </div>
      )}

      {/* Navigation - matches legacy structure exactly */}
      <div className="the-nav the-nav--large" style={{ 
        position: 'fixed',
        top: '135px',
        right: '70px',
        bottom: '105px',
        left: '980px'
      }}>
        <KioskNav />
      </div>

      {/* Active Cart Button - conditional rendering */}
      {enabledContinuousCart && (
        <div className="active-button-container">
          {/* Active Cart Button would go here */}
        </div>
      )}
    </div>
  );
}
