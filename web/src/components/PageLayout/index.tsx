import Head from "next/head";
import { ReactNode } from "react";

interface Props {
	children?: ReactNode
	data: any
	title?: string
}

export default function PageLayout({ children, title, data }: Props) {
	const pageTitle = [data.name, title].filter(part => !!part).join(' - ')
	return (
		<div className="container">
			<Head>
				<title>{data && data.name} - {pageTitle}</title>
				<link rel="icon" href="/favicon.ico" />
			</Head>
			<header>
				<nav>
					<h1>{data && data.name}</h1>
					<menu></menu>
				</nav>
			</header>
			<main>
				{children}
			</main>
			<footer>
				<p>Footer</p>
			</footer>
		</div>
	)
}
