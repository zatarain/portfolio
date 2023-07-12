import Image from 'next/image'
import Link from 'next/link'
import { SyntheticEvent } from 'react'
import { useAppDispatch, useAppSelector } from '#hooks'
import { closeResponsiveMenu, flipResponsiveMenu, selectResponsive } from './slice'
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

	const onDownloadClick = (event: SyntheticEvent) => {
		event.preventDefault()
		window.print()
	}

	return (
		<nav id="navigation-bar" className={`${styles['navigation-bar']} ${className}`} role="menubar">
			<Link href="/" className={styles.logo}>
				<Image alt="logo" src="/logo.svg" width="48" height="48" />
				{name}
			</Link>
			<ul className={styles.sections}>
				<li>
					<Link href="/#work-experience" scroll={false} onClick={() => dispatch(closeResponsiveMenu())}>Experience</Link>
				</li>
				<li>
					<Link href="/#education" scroll={false} onClick={() => dispatch(closeResponsiveMenu())}>Education</Link>
				</li>
				<li>
					<Link href="/#academic-projects" scroll={false} onClick={() => dispatch(closeResponsiveMenu())}>Academic Projects</Link>
				</li>
				<li>
					<Link href="/#leadership" scroll={false} onClick={() => dispatch(closeResponsiveMenu())}>Leadership</Link>
				</li>
				<li className={styles.action}>
					<Link href="#" className={styles['call-to-action']} onClick={onDownloadClick}>Download</Link>
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
