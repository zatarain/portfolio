import Async from 'react-async'
import { remark } from 'remark'
import remarkParse from 'remark-parse'
import remarkGfm from 'remark-gfm'
import remarkRehype from 'remark-rehype'
import rehypeStringify from 'rehype-stringify'
import remarkMath from 'remark-math'
import rehypeKatex from 'rehype-katex'

import styles from './index.module.css'
import React from 'react'

interface Properties {
	content?: string
}

const render = async ({ input }: { input: string }, { signal }: { signal: never }) => {
	console.log('input:', input)
	const content = await remark()
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
		.process(input)

	console.log('render:', String(content))
	return content
}

const Markdown = ({ content }: Properties) => {
	return (
		<Async promiseFn={render} input={content}>
			<Async.Pending>Loading...</Async.Pending>
			<Async.Rejected>{error => <p>Something went wrong: {error.message}</p>}</Async.Rejected>
			<Async.Fulfilled>{data => <div className={styles.markdown} dangerouslySetInnerHTML={{ __html: String(data) }}></div>}</Async.Fulfilled>
		</Async>
	)
}

export default Markdown
