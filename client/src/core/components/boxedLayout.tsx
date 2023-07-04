import { AppBar, Box, Container, GlobalStyles, IconButton, Toolbar } from "@mui/material";
import { useTheme } from "@mui/material/styles";
import SettingsIcon from "@mui/icons-material/Settings";
import React, { useState } from "react";
import Logo from "./logo";
//import SettingsDrawer from "./SettingsDrawer";

type BoxedLayoutProps = {
  children: React.ReactNode;
};

const BoxedLayout = ({ children }: BoxedLayoutProps) => {
  const theme = useTheme();
  const [settingsOpen, setSettingsOpen] = useState(false);

  const handleSettingsToggle = () => {
    setSettingsOpen(!settingsOpen);
  };

  return (
    <React.Fragment>
      <GlobalStyles
        styles={{ body: { backgroundColor: theme.palette.background.paper } }}
      />
      <AppBar color="transparent" position="relative" elevation={0}>
        <Toolbar>
          <Box sx={{ flexGrow: 1 }} />
          {/* <IconButton
            aria-label="settings"
            component="span"
            onClick={handleSettingsToggle}
          >
            <SettingsIcon />
          </IconButton> */}
        </Toolbar>
      </AppBar>
      <Container component="main" maxWidth="xs" sx={{ mt: 6 }}>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
          }}
        >
          <Logo sx={{ mb: 2 }} />
          {children}
          <Box>
            {/* <SettingsDrawer
              onDrawerToggle={handleSettingsToggle}
              open={settingsOpen}
            /> */}
          </Box>
        </Box>
      </Container>
    </React.Fragment>
  );
};

export default BoxedLayout;
