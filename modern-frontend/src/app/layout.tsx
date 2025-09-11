import type { Metadata } from "next";
import "./globals.css";
import "../styles/design-system.css";

export const metadata: Metadata = {
  title: "TPB Modern Frontend",
  description: "Modern frontend conversion of TPB kiosk application",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        {children}
      </body>
    </html>
  );
}
