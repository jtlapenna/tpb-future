import { Card, CardContent, Typography } from "@mui/material";
export function ProductCard({ name }: { name: string }) {
  return (
    <Card variant="outlined"><CardContent><Typography>{name}</Typography></CardContent></Card>
  );
}
