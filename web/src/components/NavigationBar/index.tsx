import Image from 'next/image'
import Link from 'next/link'
import { SyntheticEvent } from 'react'
import { useAppDispatch, useAppSelector } from '#hooks'
import { flipResponsiveMenu, selectResponsive } from './slice'
import styles from './index.module.css'

interface Properties {
	name: string
}

const NavigationBar = ({ name }: Properties) => {
	const dispatch = useAppDispatch()
	const responsive = useAppSelector(selectResponsive)
	const className = responsive ? styles.responsive : ''
	const onOpenMenuClick = (event: SyntheticEvent) => {
		event.preventDefault()
		dispatch(flipResponsiveMenu())
	}

	return (
		<nav id="navigation-bar" className={`${styles['navigation-bar']} ${className}`} role="menubar">
			<Link href="/" className={styles.logo}>
				<Image alt="logo" src="/logo.svg" width="48" height="48" />
				{name}
			</Link>
			<ul className={styles.sections}>
				<li><Link href="#work-experience" scroll={false}>Experience</Link></li>
				<li><Link href="#education" scroll={false}>Education</Link></li>
				<li><Link href="#" scroll={false}>Skills</Link></li>
				<li><Link href="#academic-projects" scroll={false}>Projects</Link></li>
				<li><Link href="#volunteering" scroll={false}>Hobbies</Link></li>
				<li className={styles.action}><Link href="#">E-mail</Link></li>
				<li className={styles.action}>
					<Link href="#" className={styles['call-to-action']}>Download</Link>
				</li>
				<li className={styles.dropdown}>
					<Link href="#" onClick={onOpenMenuClick} role="menuitemcheckbox">
						<i className="fa fa-bars"></i>
					</Link>
				</li>
			</ul>
		</nav>
	)
}

export default NavigationBar
