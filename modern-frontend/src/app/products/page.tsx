"use client";
import { useQuery } from "@tanstack/react-query";
import { http } from "@/shared/http/client";
import { ProductCard } from "@/components/ProductCard";
export default function ProductsPage() {
  const { data } = useQuery({ queryKey: ["products"], queryFn: async () => (await http.get("/api/products")).data });
  undefined