import { useState } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import styles from './index.module.css'

interface Properties {
	name: string
}

const NavigationBar = ({ name }: Properties) => {
	const [isResponsive, setResponsive] = useState(false)
	const responsive = isResponsive ? styles.responsive : ''
	const toggleResponsive = (event: any) => {
		event.preventDefault()
		setResponsive(!isResponsive)
	}

	return (
		<nav id="navigation-bar" className={`${styles['navigation-bar']} ${responsive}`} role="menubar">
			<Link href="/" className={styles.logo}>
				<Image alt="logo" src="/logo.svg" width="48" height="48" />
				{name}
			</Link>
			<ul className={styles.sections}>
				<li><Link href="#">Experience</Link></li>
				<li><Link href="#">Education</Link></li>
				<li><Link href="#">Skills</Link></li>
				<li><Link href="#">Projects</Link></li>
				<li><Link href="#">Hobbies</Link></li>
				<li className={styles.action}><Link href="#">E-mail</Link></li>
				<li className={styles.action}>
					<Link href="#" className={styles['call-to-action']}>Download</Link>
				</li>
				<li className={styles.dropdown}>
					<Link href="#" onClick={toggleResponsive} role="menuitemcheckbox">
						<i className="fa fa-bars"></i>
					</Link>
				</li>
			</ul>
		</nav>
	)
}

export default NavigationBar
