import MarkdownIt from 'markdown-it'
import styles from './index.module.css'

interface Properties {
	className?: string
	content?: string
}

const katex = require('@vscode/markdown-it-katex')

const Markdown = ({ content, className }: Properties) => {
	const markdown = MarkdownIt()
	markdown.use(katex, {
		throwOnError: false,
		errorColor: '#cc0000',
		macros: {
			'\\diff': '\\mathrm{d}'
		}
	})
	const output = markdown.render(content || '')

	return (
		<div className={`${styles.markdown} ${className}`} dangerouslySetInnerHTML={{ __html: output }}></div>
	)
}

export default Markdown
