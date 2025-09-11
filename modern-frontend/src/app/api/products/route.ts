import { NextResponse } from "next/server";
export async function GET() {
  return NextResponse.json([
    { id: "p1", name: "Gummy Bears 10mg" },
    { id: "p2", name: "Sativa Flower 3.5g" },
    { id: "p3", name: "Vape Cart 1g" }
  ]);
}
