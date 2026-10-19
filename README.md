# Dev Banner Kit

Animated, bilingual (English / Spanish) marketing kit for a programming and web development studio: mobile ad banners, Instagram stories, static social posts, and a responsive landing page with a contact form.

**Live demo:** https://dev-banner-kit.vercel.app

## What's inside

| File | Description |
| --- | --- |
| `landing.html` | Bilingual responsive landing page: hero with embedded live banner, services, formats gallery, contact form, footer. Served at `/` on Vercel. |
| `index.html` | 300x600 animated mobile banner, bilingual - auto-switches EN/ES every 6 seconds |
| `banner-en.html` / `banner-es.html` | 300x600 animated banners, single language |
| `story.html` | 1080x1920 animated Instagram story, bilingual |
| `story-en.html` / `story-es.html` | 1080x1920 animated stories, single language |
| `post-en.html` / `post-es.html` | 1080x1080 static (non-animated) social posts, with brand name, role, and domain |
| `og.html` | 1200x628 link-preview (Open Graph) image, English or Spanish via `?lang=es` |
| `social-copy.md` | Ready-to-post captions: Instagram/Facebook, story overlays, LinkedIn, X, taglines, bios, hashtags (EN + ES) |
| `exports/` | Rendered PNGs at full resolution (300x600, 1080x1920, 1080x1080, 1200x628) |
| `brand.json` | Brand name, domains, email, and 5-color palette - single source of truth |
| `reskin.ps1` | One command to rebrand everything: names, contacts, and colors |
| `build-variants.ps1` | Regenerates the single-language banners/stories from the bilingual sources |
| `export-pngs.ps1` | Renders all PNGs via headless Edge/Chrome into `exports/` |
| `vercel.json` | Vercel config: serves `landing.html` at the site root and at `/es` (Spanish) |

## Preview locally

Open `landing.html` directly in a browser, or serve the folder:

```powershell
npx serve .
```

## Languages

- Pages carry both languages in one file via `data-en` / `data-es` attributes. The landing page has an EN/ES toggle; the bilingual banner and story auto-rotate every 6-7 seconds.
- Single-language variants exist for ad platforms that require one locale per creative.

## URL parameters

| Parameter | Applies to | Effect |
| --- | --- | --- |
| `?embed=1` | banner EN/ES | Hides the caption - fit for iframes |
| `?still=1` | banner, story | Renders the code block fully typed, no animation |
| `?flat=1` | banner EN/ES | Anchors content to the top-left (used by the export script) |
| `?full=1` | story, post, og | Exact-pixel layout for screenshot capture |
| `?lang=es` | og | Renders the preview card in Spanish |

## Reskin (rebrand in one command)

```powershell
powershell -ExecutionPolicy Bypass -File reskin.ps1 -Brand "Acme Labs" -Domain "acme.dev" -DomainEs "acme.es" -Email "hola@acme.dev" -C1 "#0ea5e9" -C2 "#7c3aed" -C3 "#ec4899" -C4 "#10b981" -C5 "#f59e0b"
```

Reads and updates `brand.json`, then rewrites the brand name, domains, email, brand color hexes, and rgba shades across every banner, story, post, landing page, and the social copy. Run `export-pngs.ps1` afterwards to refresh the PNGs.

All `.ps1` scripts must stay UTF-8 with BOM (Windows PowerShell 5.1 and Spanish accented strings).

## Export PNGs

```powershell
powershell -ExecutionPolicy Bypass -File export-pngs.ps1
```

Requires Edge or Chrome (headless). Writes exact 300x600, 1080x1920, and 1080x1080 PNGs into `exports/`. The script oversizes the headless window and crops the screenshot, because headless Chromium enforces minimum window sizes.

## Contact form

`landing.html` posts to Formspree. Replace `YOUR_FORM_ID` in the form `action` URL with your own ID from formspree.io. Until then the form runs in demo mode: it validates and shows the success state without sending.

## Deploy

- Vercel (production): https://dev-banner-kit.vercel.app

```powershell
vercel deploy --prod
```

- GitHub: https://github.com/HarleyVasquezcom/dev-banner-kit

`vercel.json` rewrites `/` and `/es` to `landing.html`; every banner, story, and post is also directly reachable by path. The landing page carries Open Graph and Twitter card meta tags using `exports/og-en-1200x628.png` as the preview image.

## Regenerate single-language variants

```powershell
powershell -ExecutionPolicy Bypass -File build-variants.ps1
```

Run this after editing the bilingual `index.html` or `story.html` so the single-language variants stay in sync.

## Resumen (espanol)

- Kit bilingue (ingles / espanol) para estudio de programacion y desarrollo web: banners animados 300x600, stories 1080x1920, posts estaticos 1080x1080 y landing page con formulario de contacto.
- Demo en vivo: https://dev-banner-kit.vercel.app
- Rebranding en un comando: `reskin.ps1` (nombre, dominios, email y colores). Exportar PNGs: `export-pngs.ps1`.
- Formulario: reemplazar `YOUR_FORM_ID` por el ID real de Formspree.
