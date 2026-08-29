const stub = new URL('./controller_stub.mjs', import.meta.url).href

export async function resolve(specifier, context, next) {
  if (specifier === '@hotwired/stimulus') return { shortCircuit: true, url: stub }
  return next(specifier, context)
}
