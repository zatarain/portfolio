import Async from 'react-async'
import type { AsyncProps } from 'react-async'
import { remark } from 'remark'
import remarkParse from 'remark-parse'
import remarkGfm from 'remark-gfm'
import remarkRehype from 'remark-rehype'
import rehypeStringify from 'rehype-stringify'
import remarkMath from 'remark-math'
import rehypeKatex from 'rehype-katex'

import styles from './index.module.css'
import React from 'react'

interface Properties extends AsyncProps<string> {
	content?: string
}

const render = async ({ content }: Properties) => {
	console.log('input:', content)
	const output = await remark()
		.use(remarkParse)
		.use(remarkGfm)
		.use(remarkMath)
		.use(remarkRehype)
		.use(rehypeKatex, {
			macros: {
				'\\diff': '\\mathrm{d}',
			}
		})
		.use(rehypeStringify)
		.process(content || '')

	console.log('render:', String(output))
	return new Promise<string>((resolve) => resolve(String(output)))
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
