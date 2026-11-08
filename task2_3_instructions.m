%[text] # Agentic AI Workflow: Tasks 2 - 3
%[text] These exercises use agents to run, change, assess, and plan improvements to a MATLAB market-risk analysis project.
% Move into the folder for this exercise.
scriptFile = matlab.desktop.editor.getActiveFilename;
scriptDir = fileparts(scriptFile);
cd(fullfile(scriptDir,"start-here"))
%%
%[text] Open a terminal and start Codex
% Open a Terminal in MATLAB.
myTerminal = terminal(Theme="dark",StartupCommand="codex");
%%
%[text] ## Task 2: Running and changing code
%[text] #### What is the project about?
%[text] Copy and paste each prompt below into Codex (use ctrl+shift+v to copy into the terminal), or run its code block.
%[text] Ask the agent to orient itself in the project before making changes. This is a good way to establish context if you don't have a README file.
%[text] `Tell me about the project in this directory`
myTerminal.run("Tell me about the project in this directory");
pause(1)
myTerminal.run("");
%%
%[text] Run the existing workflow to establish its current behaviour and look at the visualizations that accompany it.
%[text] `Please run the entry script`
myTerminal.run("Please run the entry script");
pause(1)
myTerminal.run("");
%%
%[text] The current project compares the UK FTSE with the CAC. Update the comparison to use UK FTSE and Asian index returns instead.
%[text] `Please update the code to compare the UK FTSE with Asian index returns`
myTerminal.run("Please update the code to compare the UK FTSE with Asian index returns");
pause(1)
myTerminal.run("");
%[text] **Question:** Try updating to other indices. Is the agent following a consistent approach every time? Is there a better way to approach this sort of problem if you need to change the indices being compared frequently?
%%
%[text] #### Refactor the import script into a reusable function
%[text] Instead of repeated ad-hoc changes, we'll turn the data-import script into a reusable function that accepts input parameters.
%[text] `Refactor the @importMarketData.m script into a clean, reusable function.`
myTerminal.run("Refactor the @importMarketData.m script into a clean, reusable function.");
pause(1)
myTerminal.run("");
%[text] **Question:** Inspect the resulting function. Is it general purpose? What should change? What else changed?
%[text] **Sub-task:** Give the agent instructions to improve the refactor and try again.
%[text] Use the code block below with your own prompt:
myTerminal.run("YOUR PROMPT HERE");
pause(1)
myTerminal.run("");
%%
%[text] **Tips:**
%[text] In some of my runs, the new import function allowed specifying new data files, but not the indices to compare. Here's an example of a prompt I used to fix that: 
%[text] `The importMarketData.m function allows specifying different data files, but I want to be able to call the function and specify different indices by name. The function should return returns, dates and series names for the specified indices.`
%[text] In some of my runs, the agent made a function, but it didn't take in any arguments at all. Here's an example of a prompt I used to fix that:
%[text] `It is a function, but I'm unable to specify any arguments. I want to be able to specify alternative data source files (though it should default to the ones in there now). And I want to be able to call the function and specify different indices by name. The function should return returns, dates and series names for the specified indices.`
myTerminal.run("It is a function, but I'm unable to specify any arguments. I want to be able to specify alternative data source files (though it should default to the ones in there now). And I want to be able to call the function and specify different indices by name. The function should return returns, dates and series names for the specified indices.");
pause(1)
myTerminal.run("");
%[text] **Question:** How could we have done better here?
%%
%[text] #### Learning from mistakes
%[text] Ask the agent to reflect on what just happened and whether there's a more general lesson to carry forward to future sessions.
%[text] `What did you learn from that course correction?`
myTerminal.run("What did you learn from that course correction?");
pause(1)
myTerminal.run("");
%%
%[text] Record the lesson in the project's AGENTS.md for reuse.
%[text] `Update AGENTS.md to reflect this learning in a way that's generally applicable going forward.`
myTerminal.run("Update AGENTS.md to reflect this learning in a way that's generally applicable going forward.");
pause(1)
myTerminal.run("");
%%
%[text] ## Task 3: Approaching Refactors with Regression Tests
%[text] Open `analyzeTailRisk` and see if you can spot any bad coding practices (before we ask the agent to do anything).
%[text] If you want to refactor a function, it's often useful to make use of "regression tests" to capture the current behvaiour of the test before you make changes. Then you have an automatic sanity check to make sure you haven't changed the behaviour.
%[text] Establish the current behaviour with an example where the code should run correctly ("a happy-path") and edge-case tests before making changes. Here, we're going to use planning mode to have greater control over the agent's actions before it starts with any of the tasks.
%[text] `/plan Add tests for analyzeTailRisk to establish a baseline of the current behaviour testing both the happy (obvious) path and edge cases. Plan out the cases we should use step by step, including a summary as part of the plan.`
myTerminal.run("/plan Add tests for analyzeTailRisk to establish a baseline of the current behaviour testing both the happy (obvious) path and edge cases. Plan out the cases we should use step by step, including a summary as part of the plan.");
pause(1)
myTerminal.run("");
%[text] **Question:** Open the resulting tests - do they make sense? Are they a good characterization of the function?
%%
%[text] Ask a separate analysis-focused agent or context to identify maintainability issues without changing the code.
%[text] `Please analyze the @analyzeTailRisk file in this repo for quality and maintainability issues. Flag any code smells. Don't change anything yet, but make recommendations for improvement`
myTerminal.run("Please analyze the @analyzeTailRisk file in this repo for quality and maintainability issues. Flag any code smells. Don't change anything yet, but make recommendations for improvement");
pause(1)
myTerminal.run("");
%%
%[text] Plan the highest-priority improvements.
%[text] `/plan Please plan out how the top three recommendations should be implemented, in slices for large chunks of work. After each slice of work, first verify correctness by running the regression tests before continuing to the next slice.`
myTerminal.run("/plan Please plan out how the top three recommendations should be implemented, in slices for large chunks of work. After each slice of work, first verify correctness by running the regression tests before continuing to the next slice.");
pause(1)
myTerminal.run("");
%[text] Use separate agent contexts for code-smell analysis and regression-test authoring when independent validation is important.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
