import Async from 'react-async'
import type { AsyncProps } from 'react-async'
import MarkdownIt from 'markdown-it'
import styles from './index.module.css'

interface Properties extends AsyncProps<string> {
	content?: string
}
const katex = require('@vscode/markdown-it-katex')

const render = (content: string) => {
	const markdown = MarkdownIt()
	markdown.use(katex, {
		throwOnError: false,
		errorColor: '#cc0000',
		macros: {
			'\\diff': '\\mathrm{d}'
		}
	})
	return markdown.render(content)
}

const Markdown = ({ content }: Properties) => {
	return (
		<div className={styles.markdown} dangerouslySetInnerHTML={{ __html: render(content || '') }}></div>
	)
}

export default Markdown
