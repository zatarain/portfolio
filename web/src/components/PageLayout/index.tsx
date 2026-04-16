import type { CurriculumVitaeProperties } from '#components/CurriculumVitae'
import Footer from '#components/Footer';
import Head from 'next/head';
import Header from '#components/Header';
import NavigationBar from '#components/NavigationBar';
import { Fira_Sans } from "next/font/google";
import { ReactNode } from 'react';

import styles from './index.module.css'

interface Properties {
	children?: ReactNode,
	data?: CurriculumVitaeProperties,
	title?: string,
	hero?: boolean,
	className?: string,
}

const firaSans = Fira_Sans({
	subsets: ['latin'],
	weight: ['300', '400', '500', '600', '700'],
	variable: '--font-fira-sans',
});

export default function PageLayout({ children, title, data, hero = true, className = '' }: Properties) {
	const pageTitle = [data?.name, title].filter(part => !!part).join(' - ')
	const name = data?.name || pageTitle;
	const pass = data || { name }

	return (
		<div className={`${styles.container} ${className} ${firaSans.variable} ${styles['font-fira-sans']}`}>
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
