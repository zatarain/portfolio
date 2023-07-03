import Async from 'react-async'
import type { AsyncProps } from 'react-async'
import MarkdownIt from 'markdown-it'
import styles from './index.module.css'

interface Properties extends AsyncProps<string> {
	content?: string
}

const render = async ({ content }: Properties) => {
	const katex = require('@vscode/markdown-it-katex')
	const markdown = MarkdownIt()
	markdown.use(katex, {
		throwOnError: false,
		errorColor: '#cc0000',
		macros: {
			'\\diff': '\\mathrm{d}'
		}
	})
	return markdown.render(content || '')
}

const Markdown = ({ content }: Properties) => {
	return (
		<Async promiseFn={render} content={content}>
			<Async.Pending>Loading...</Async.Pending>
			<Async.Rejected>{error => <p>Something went wrong: {error.message}</p>}</Async.Rejected>
			<Async.Fulfilled>{data => <div className={styles.markdown} dangerouslySetInnerHTML={{ __html: String(data) }}></div>}</Async.Fulfilled>
		</Async>
	)
}

export default Markdown
