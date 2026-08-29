import { registerHooks } from 'node:module'
import { pathToFileURL } from 'node:url'

// Maps the gem's importmap names and the Stimulus dependency to real files so
// Node can load the browser modules directly.
const MODULES = new URL('../../app/assets/javascripts/stimulus_table_filter/', import.meta.url)

registerHooks({
  resolve(specifier, context, nextResolve) {
    if (specifier.startsWith('stimulus_table_filter/')) {
      const name = specifier.slice('stimulus_table_filter/'.length)
      return { shortCircuit: true, url: pathToFileURL(new URL(`${name}.js`, MODULES).pathname).href }
    }
    if (specifier === '@hotwired/stimulus') {
      const stub = pathToFileURL(new URL('./controller_stub.mjs', import.meta.url).pathname).href
      return { shortCircuit: true, url: stub }
    }
    return nextResolve(specifier, context)
  }
})
