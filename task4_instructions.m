%[text] # Agentic AI Workflow: Task 4 - Big refactor
%[text] In this exercise, we use an agent to turn the market-risk analysis into a properly managed MATLAB project and we plan a test-driven modular refactor.
%[text] Continue your project where you left off, or copy the Task 3 solution from the solutions folder and continue from there.
%%
%[text] ### Step 1: Open a terminal and start Codex
myTerminal = terminal(Theme="dark",StartupCommand="codex");
%%
%[text] ### Step 2: Set up the project, version control, and testing rules
%[text] We can use agents to set up MATLAB project path management, local version control, and test-driven development rules.
%[text] `Please make this project into a proper Matlab project (so that the project does path management for us). Also initialize a git repository here and add instructions to agents.md to use it for version control. Commit after every change is verified, but do not push or make any changes to remote without explicit user permission. Also add instructions to follow proper test-driven development principles, with red/green states. Prioritize the targeted test before running the whole suite.`
myTerminal.run("Please make this project into a proper Matlab project (so that the project does path management for us). Also initialize a git repository here and add instructions to agents.md to use it for version control. Commit after every change is verified, but do not push or make any changes to remote without explicit user permission. " + newline + ...
    "Also add instructions to follow proper test-driven development principles, with red/green states. Prioritize the targeted test before running the whole suite.");
pause(1)
myTerminal.run("");
%%
%[text] ### Step 3: Plan the modular refactor
%[text] Create a saved, test-first plan to turn each non-entry-point script into a modular function.
%[text] `/plan Apart from the entry point script, the other scripts should be converted into reusable, modular functions. Please plan this out step by step, with a slice of work for each function. In each case, add a quick regression test for the script that uses simulated data to capture existing behaviour and detect divergence from the current behaviour. Include writing the plan to file for future reference as the first step.`
myTerminal.run("/plan Apart from the entry point script, the other scripts should be converted into reusable, modular functions. Please plan this out step by step, with a slice of work for each function. In each case, add a quick regression test for the script that uses simulated data to capture existing behaviour and detect divergence from the current behaviour. Include writing the plan to file for future reference as the first step.");
pause(1)
myTerminal.run("");
%%
%[text] Doing the refactor can take considerable time, so we provide an example outcome in the Task 4 solution folder. Depending on time, we may leave the execution as an exercise for the reader.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
