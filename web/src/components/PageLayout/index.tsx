import Header from '#components/Header';
import Head from 'next/head';
import { ReactNode } from 'react';
import { Inter } from 'next/font/google'
import Footer from '#components/Footer';

import styles from './index.module.css'

interface Properties {
	children?: ReactNode
	data: {
		name: string
	}
	title?: string
}

export default function PageLayout({ children, title, data }: Properties) {
	const inter = Inter({ subsets: ['latin'] })
	const pageTitle = [data?.name, title].filter(part => !!part).join(' - ')
	return (
		<div className={`${inter.className} ${styles.container}`}>
			<Head>
				<title>{pageTitle}</title>
			</Head>
			<Header data={data} />
			<main>
				{children}
			</main>
			<Footer />
		</div>
	)
}
