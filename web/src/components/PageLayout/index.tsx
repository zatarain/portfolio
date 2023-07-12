import type { CurriculumVitaeProperties } from '#components/CurriculumVitae'
import Footer from '#components/Footer';
import Head from 'next/head';
import Header from '#components/Header';
import NavigationBar from '#components/NavigationBar';
import { Inter } from 'next/font/google'
import { ReactNode } from 'react';

import styles from './index.module.css'

interface Properties {
	children?: ReactNode
	data?: CurriculumVitaeProperties,
	title?: string
	hero?: boolean
}

const inter = Inter({ subsets: ['latin'] })

export default function PageLayout({ children, title, data, hero = true }: Properties) {
	const pageTitle = [data?.name, title].filter(part => !!part).join(' - ')
	const name = data?.name || pageTitle;
	const pass = data || { name }

	return (
		<div className={`${inter.className} ${styles.container}`}>
			<Head>
				<title>{pageTitle}</title>
			</Head>
			<NavigationBar name={name} />
			{hero && <Header data={pass} />}
			<main>
				{children}
			</main>
			<Footer />
		</div>
	)
}
