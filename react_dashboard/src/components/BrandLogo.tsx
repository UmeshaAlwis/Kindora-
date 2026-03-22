import { useState } from 'react';

/** Your file: `public/brand/logo.png` only. SVG is a fallback if PNG is missing. */
const LOGO_SOURCES = ['/brand/logo.png', '/brand/logo.svg'] as const;

type Variant = 'default' | 'compact' | 'hero';

const variantClass: Record<Variant, string> = {
  default: 'brand-logo-img--default',
  compact: 'brand-logo-img--compact',
  hero: 'brand-logo-img--hero',
};

/**
 * Kindora logo for the admin app. Add your assets to `public/brand/`
 * (see `public/brand/README.md`).
 */
export function BrandLogo({
  variant = 'default',
  className = '',
}: {
  variant?: Variant;
  className?: string;
}) {
  const [index, setIndex] = useState(0);

  if (index >= LOGO_SOURCES.length) {
    return (
      <span
        className={`brand-logo-fallback ${variantClass[variant]} ${className}`.trim()}
        aria-label="Kindora"
      >
        Kindora
      </span>
    );
  }

  return (
    <img
      className={`brand-logo-img ${variantClass[variant]} ${className}`.trim()}
      src={LOGO_SOURCES[index]}
      alt="Kindora"
      decoding="async"
      onError={() => setIndex((i) => i + 1)}
    />
  );
}
