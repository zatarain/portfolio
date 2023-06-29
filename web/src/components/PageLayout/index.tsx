import type { CurriculumVitaeProperties } from '#components/curriculum-vitae'
import Footer from '#components/Footer';
import Head from 'next/head';
import Header from '#components/Header';
import { Inter } from 'next/font/google'
import { ReactNode } from 'react';

import styles from './index.module.css'

interface Properties {
	children?: ReactNode
	data: CurriculumVitaeProperties,
	title?: string
}

const inter = Inter({ subsets: ['latin'] })

export default function PageLayout({ children, title, data }: Properties) {
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
