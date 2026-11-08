%[text] # Agentic AI Workflow: Task 5 - Build an app
%[text] In this exercise, we use an agent to plan and build a MATLAB app for visualizing market data inputs and simulated returns.
%[text] Continue where we left off or copy the Task 3 solution from the solutions folder and continue from there.
%%
%[text] ### Step 1: Open a terminal and start Codex
myTerminal = terminal(Theme="dark",StartupCommand="codex");
%%
%[text] ### Step 2: Clear the current agent context
%[text] Start with a fresh agent context for the app-design task.
%[text] `/clear`
myTerminal.run("/clear");
pause(1)
myTerminal.run("");
%%
%[text] ### Step 3: Plan the app
%[text] Create a saved plan for an app that compares selected market indices and their simulated returns side by side.
%[text] `/plan Please build a MATLAB app (as a .m file) to help the user visualize the different market data inputs and their simulated returns. THe user should be able to choose between different indices in Data_GLobalIdx1.mat and the Asian Index returns. The app should plot everything as in plotRiskResults, but side by side, contingent on the user-chosen data. Plan this out step by step, asking me for anything that's unclear. Include writing the plan to file for future reference as the first step.`
myTerminal.run("/plan Please build a MATLAB app (as a .m file) to help the user visualize the different market data inputs and their simulated returns. THe user should be able to choose between different indices in Data_GLobalIdx1.mat and the Asian Index returns. The app should plot everything as in plotRiskResults, but side by side, contingent on the user-chosen data. Plan this out step by step, asking me for anything that's unclear. Include writing the plan to file for future reference as the first step.");
pause(1)
myTerminal.run("");

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
