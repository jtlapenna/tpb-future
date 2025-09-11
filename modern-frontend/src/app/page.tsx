import { HomeScreen } from "@/components/HomeScreen";

export default function HomePage() {
  // Configuration - in real app this would come from context/API
  const config = {
    rfidEnabled: false, // Set to true to show animation, false to show text
    customWelcomeMessage: null, // Set to a string to show custom message
    enabledContinuousCart: false, // Set to true to show active cart button
    storeLogoUrl: "/static/img/default-store-logo.svg",
    storeLogoType: 'horizontal' as const
  };

  return <HomeScreen {...config} />;
}