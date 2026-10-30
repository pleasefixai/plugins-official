---
name: scaffold-lovable-project
description: Start a new Lovable app from a plain-language brief and hand back the editor and preview links. Use when someone wants to spin up a fresh project.
---

# Scaffold a Lovable project

## When to use

- Someone describes an app they want and there is no project yet.
- You are prototyping and need a running starting point fast.

## What you have to work with

New projects use Lovable's default stack (TypeScript, Tailwind, shadcn/ui, with a cloud sandbox and live preview). There is no stack picker in `create_project`. If the brief implies a framework, rendering style, or layout, write it into the prompt in plain words.

## Steps

1. Turn the brief into one concrete `create_project` prompt. Name the kind of app, the main screens, and the first thing a visitor should be able to do. Skip vague adjectives; describe behavior.
2. Call `create_project`. If a host renders the project widget, omit `workspace_id` and let the widget pick the workspace; otherwise pass the workspace you mean.
3. Wait for the first build, then capture `editor_url` and `preview_url` from the project.
4. Open the `preview_url` (or `get_diff`) to confirm the first build matches the brief.
5. Hand back both links: the editor for visual edits, the preview to look at the running app.

## Good first prompts

- Say what the app is for, not just what it is. "A booking page where a client picks a time slot and pays a deposit" beats "a scheduling app."
- Name the first screen and the primary action on it.
- Mention any integration up front (Stripe, Supabase auth, email) so it is planned in, not bolted on later.

## After it exists

Hand off to the iterate-with-lovable-agent skill to refine it, or enable-lovable-cloud-database if it needs data.
