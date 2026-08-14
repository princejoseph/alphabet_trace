# Alphabet Trace

A tiny app for kids to practice writing the alphabet. Each letter shows a
solid reference glyph next to a dotted trace guide with a canvas overlay —
draw over the dots with your mouse or finger, then move to the next letter.

## How it works

- `/a` through `/z` each show one letter, with **Previous** / **Next** links
  to move through the alphabet (disabled at the ends).
- The left pane is a solid reference letter; the right pane is the same
  letter drawn as a dotted outline with a transparent `<canvas>` on top —
  trace over the dots to practice.
- **Clear** wipes the canvas so a letter can be retried.
- Letters are rendered as SVG text, not image files, so there are no
  per-letter assets to manage — the whole alphabet comes from one component.

## Stack

- Ruby 3.1, Rails 7.2
- [Hyperstack](https://hyperstack.org) — the whole UI (`AlphabetTraceApp`) is
  one Ruby component, compiled to JavaScript via Opal, with no ActionCable
  (`Hyperstack.transport = :none`) since there's nothing to sync — it's a
  single-player, client-side drawing surface
- Plain Rails routing (`/:letter` → `AlphabetController#show`) rather than
  Hyperstack's client-side router — full page loads between letters are
  cheap here and naturally reset the canvas for each new letter
- SQLite (unused beyond the Rails default — there are no models)
- Gems pull from the [`princejoseph/hyperstack`](https://github.com/princejoseph/hyperstack)
  fork's `rails-7-compatibility` branch, which backports Rails 7 / Ruby 3
  fixes ahead of upstream

## Getting started

```bash
bundle install
bin/rails server
```

Visit http://localhost:3000 — it redirects to `/a`.

First request per boot is slow (~10s) while Opal compiles the component;
subsequent requests are served from cache.

## Testing

```bash
bundle exec rspec
```

- `spec/requests` — routing/controller behavior (valid/invalid letters, redirects)
- `spec/system` — full-page browser specs (headless Chrome) covering the
  assembled page: drawing, Clear, navigation
- `spec/components` — unit-level specs for one Hyperstack component at a
  time, via [hyper-spec](https://github.com/hyperstack-org/hyper-spec)'s
  `mount("ComponentName", prop: value)`, independent of any route/controller.
  **Add one of these for each new component** as the page grows — mount it,
  assert on it, done; no need to wire it into the real page first.

Deploys are gated on this suite passing (see `.github/workflows/deploy.yml`).

## Project structure

```
app/
  controllers/
    alphabet_controller.rb        # reads params[:letter], nothing else
  hyperstack/
    components/
      hyper_component.rb          # base class for all Hyperstack components
      alphabet_trace_app.rb       # reference letter, trace guide, canvas, nav
  views/
    alphabet/
      show.html.erb               # mounts AlphabetTraceApp via react_component
config/
  routes.rb                       # get "/:letter", constrained to [a-z]
```
