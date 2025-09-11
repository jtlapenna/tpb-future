"use client";
import { Box, Button, Typography } from "@mui/material";
import Link from "next/link";

export default function BlankPage() {
  return (
    <Box display="grid" justifyContent="center" alignContent="center" height="70vh" gap={2}>
      <Typography variant="h5">This is the converted Blank page</Typography>
      <Typography variant="body2" color="text.secondary">Use this route to validate the foundation and future conversions.</Typography>
      <Button component={Link} href="/" variant="contained">Go Home</Button>
    </Box>
  );
}
