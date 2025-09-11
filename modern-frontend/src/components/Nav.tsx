"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Box, Button, Typography } from "@mui/material";
import { NAV } from "@/config/nav";

export function Nav() {
  const pathname = usePathname();
  return (
    <Box component="nav" sx={{ p: 3 }}>
      <Box sx={{ display: "flex", gap: 2, flexWrap: "wrap" }}>
        {NAV.map((link, idx) => {
          const active = pathname === link.path;
          return (
            <Button
              key={link.path}
              component={Link}
              href={link.path}
              variant={active ? "contained" : "outlined"}
              color={active ? "primary" : "inherit"}
              sx={{ minWidth: 180, justifyContent: "flex-start" }}
            >
              <Box>
                <Typography variant="subtitle2">{String(idx + 1).padStart(2, "0")}</Typography>
                <Typography variant="h6" sx={{ lineHeight: 1.1 }}>{link.title}</Typography>
                {link.description && (
                  <Typography variant="caption" color="text.secondary">{link.description}</Typography>
                )}
              </Box>
            </Button>
          );
        })}
      </Box>
    </Box>
  );
}
